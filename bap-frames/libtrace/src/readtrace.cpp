/**
 * New c++ trace reader.  Tests c++ TraceContainerReader API.
 */

#include <cassert>
#include <exception>
#include <iostream>
#include "trace.container.hpp"

using namespace SerializedTrace;

void print(frame &f) {
  std::cout << f.DebugString() << std::endl;
}

void print_all(const char *f) {
  uint64_t ctr = 0;

  TraceContainerReader t(f);

  std::cout << t.get_meta()->DebugString() << std::endl;

  while (!t.end_of_trace()) {
    ctr++;
    print(*(t.get_frame()));
  }

  assert(ctr == t.get_num_frames());
}

int main(int argc, char **argv) {
  if (argc != 2) {
    if (argv[0]) {
      std::cout << "Usage: " << argv[0] << " <trace>" << std::endl;
    }
    exit(1);
  }

  print_all(argv[1]);
}
