OUTPUT_ARCH("riscv")
ENTRY(_start)

/* Preserve cpu_init's mtvec value without placing the suffix in this image. */
trap_handler = 0x80000138;

SECTIONS
{
  . = 0x80000000;
  .text.init : {
    KEEP(*(.text.init))
  }

  /DISCARD/ : {
    *(.comment)
    *(.riscv.attributes)
  }
}

ASSERT(_start == 0x80000080, "_start must match the Ibex reset vector")
ASSERT(SIZEOF(.text.init) == 0x120, "common init must end at 0x8000011c")
