#include <cvd/exceptions.h>
#include <cvd/diskbuffer2.h>
#include <cvd/deinterlacebuffer.h>


using namespace std;
using namespace CVD:: Exceptions:: DeinterlaceBuffer;


OddNumberOfLines::OddNumberOfLines()
	: CVD::Exceptions::DeinterlaceBuffer::All("VideoFrame passed to DeinterlaceBuffer has an odd number of lines!")
{
}
