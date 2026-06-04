src/

The latest version of the BSD Learner. 

You only need to modify top.h:

	Line 2: change the include file to your io generator file name. For example: 		#include	"io_generator/c1908.h"	

Your io generator function in the file need to start with the following head:

	extern const int PI_WIDTH = 33;
	extern const int PO_WIDTH = 25;
	void io_generator_outer(bool* pi, bool* po) {
	}

Run: 
	sh zstart.sh

Result:

	The output Verilog files are stored in rtl/

	See function_top.v 
