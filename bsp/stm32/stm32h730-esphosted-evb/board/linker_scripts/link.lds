/*
 * linker script for STM32F4xx with GNU ld
 * bernard.xiong 2009-10-14
 */

/* Program Entry, set to mark it as "used" and avoid gc */
MEMORY
{
  ITCMRAM (xrw)    : ORIGIN = 0x00000000,   LENGTH = 64K
  DTCMRAM (xrw)    : ORIGIN = 0x20000000,   LENGTH = 128K
  FLASH    (rx)    : ORIGIN = 0x90000000,   LENGTH = 1M
  RAM_D1  (xrw)    : ORIGIN = 0x24000000,   LENGTH = 320K
  RAM_D2  (xrw)    : ORIGIN = 0x30000000,   LENGTH = 32K
  RAM_D3  (xrw)    : ORIGIN = 0x38000000,   LENGTH = 16K
}
ENTRY(Reset_Handler)
_system_stack_size = 0x400;

SECTIONS
{
    .ram_d1(NOLOAD) : {
        . = ALIGN(4);
        *(.ram_d1)
        *(.ram_d1.*)
        . = ALIGN(4);
    } >RAM_D1

    .ram_d2(NOLOAD) : {
        . = ALIGN(4);
        *(.ram_d2)
        *(.ram_d2.*)
        . = ALIGN(4);
    } >RAM_D2

    .ram_d3(NOLOAD) : {
        . = ALIGN(4);
        *(.ram_d3)
        *(.ram_d3.*)
        . = ALIGN(4);
    } >RAM_D3

    _ramfunc_start_lma = LOADADDR(.ramfunc);
    .ramfunc : {
        . = ALIGN(4);
        _ramfunc_start_vma = .;
         *(.RamFunc)        /* .RamFunc sections */
         *(.RamFunc*)       /* .RamFunc* sections */
         . = ALIGN(4);
         _ramfunc_end = .;        /* define a global symbol at data end */
    } >ITCMRAM AT>FLASH

    .text :
    {
        . = ALIGN(4);
        _stext = .;
        KEEP(*(.isr_vector))            /* Startup code */

        . = ALIGN(4);
        *(.text)                        /* remaining code */
        *(.text.*)                      /* remaining code */
        *(.rodata)                      /* read-only data (constants) */
        *(.rodata*)
        *(.glue_7)
        *(.glue_7t)
        *(.gnu.linkonce.t*)

        /* section information for finsh shell */
        . = ALIGN(4);
        __fsymtab_start = .;
        KEEP(*(FSymTab))
        __fsymtab_end = .;

        . = ALIGN(4);
        __vsymtab_start = .;
        KEEP(*(VSymTab))
        __vsymtab_end = .;

        /* section information for utest */
        . = ALIGN(4);
        __rt_utest_tc_tab_start = .;
        KEEP(*(UtestTcTab))
        __rt_utest_tc_tab_end = .;

        /* section information for at server */
        . = ALIGN(4);
        __rtatcmdtab_start = .;
        KEEP(*(RtAtCmdTab))
        __rtatcmdtab_end = .;
        . = ALIGN(4);

        /* section information for modules */
        . = ALIGN(4);
        __rtmsymtab_start = .;
        KEEP(*(RTMSymTab))
        __rtmsymtab_end = .;

        /* section information for initial. */
        . = ALIGN(4);
        __rt_init_start = .;
        KEEP(*(SORT(.rti_fn*)))
        __rt_init_end = .;

        . = ALIGN(4);

        PROVIDE(__ctors_start__ = .);
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
        PROVIDE(__ctors_end__ = .);

        PROVIDE(__dtors_start__ = .);
        KEEP (*(SORT(.fini_array.*)))
        KEEP (*(.fini_array))
        KEEP(*(SORT(.dtors.*)))
        KEEP(*(.dtors))
        PROVIDE(__dtors_end__ = .);

        . = ALIGN(4);

        _etext = .;
    } >FLASH

    /* .ARM.exidx is sorted, so has to go in its own output section.  */
    .ARM.exidx :
    {
        . = ALIGN(4);
        __exidx_start = .;
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        *(.ARM.extab*)
        . = ALIGN(4);
        __exidx_end = .;
    } >FLASH

    /* .data section which is used for initialized data */

    _sidata = LOADADDR(.data);
    _data_start_lma = LOADADDR(.data);
    .data :
    {
        . = ALIGN(4);
        /* This is used by the startup in order to initialize the .data secion */
        _sdata = . ;
        _data_start_vma = .;

        *(.data)
        *(.data.*)
        *(.gnu.linkonce.d*)


        . = ALIGN(4);
        /* This is used by the startup in order to initialize the .data secion */
        _edata = . ;
        _data_end = .;
    } >DTCMRAM AT>FLASH

    __bss_start = .;
    .bss (NOLOAD):
    {
        . = ALIGN(4);
        /* This is used by the startup in order to initialize the .bss secion */
        _sbss = .;

        *(.bss)
        *(.bss.*)
        *(COMMON)

        . = ALIGN(4);
        /* This is used by the startup in order to initialize the .bss secion */
        _ebss = . ;

        *(.bss.init)
    } > DTCMRAM
    __bss_end = .;
    _heap_start = .;
    _end = .;

    _heap_end = ORIGIN(DTCMRAM) + LENGTH(DTCMRAM) - _system_stack_size;
    _sstack = _heap_end;
    _estack = _heap_end + _system_stack_size;

    /* Stabs debugging sections.  */
    .stab          0 : { *(.stab) }
    .stabstr       0 : { *(.stabstr) }
    .stab.excl     0 : { *(.stab.excl) }
    .stab.exclstr  0 : { *(.stab.exclstr) }
    .stab.index    0 : { *(.stab.index) }
    .stab.indexstr 0 : { *(.stab.indexstr) }
    .comment       0 : { *(.comment) }
    /* DWARF debug sections.
     * Symbols in the DWARF debugging sections are relative to the beginning
     * of the section so we begin them at 0.  */
    /* DWARF 1 */
    .debug          0 : { *(.debug) }
    .line           0 : { *(.line) }
    /* GNU DWARF 1 extensions */
    .debug_srcinfo  0 : { *(.debug_srcinfo) }
    .debug_sfnames  0 : { *(.debug_sfnames) }
    /* DWARF 1.1 and DWARF 2 */
    .debug_aranges  0 : { *(.debug_aranges) }
    .debug_pubnames 0 : { *(.debug_pubnames) }
    /* DWARF 2 */
    .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_frame    0 : { *(.debug_frame) }
    .debug_str      0 : { *(.debug_str) }
    .debug_loc      0 : { *(.debug_loc) }
    .debug_macinfo  0 : { *(.debug_macinfo) }
    /* SGI/MIPS DWARF 2 extensions */
    .debug_weaknames 0 : { *(.debug_weaknames) }
    .debug_funcnames 0 : { *(.debug_funcnames) }
    .debug_typenames 0 : { *(.debug_typenames) }
    .debug_varnames  0 : { *(.debug_varnames) }
}
