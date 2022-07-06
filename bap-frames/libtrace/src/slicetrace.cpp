/**
 * Copy one trace to another to test API.
 */

#include <fstream>
#include <iostream>
#include <getopt.h>
#include <stdlib.h>     /* strtol */
#include <string>
#include <iostream>
#include <fstream>
#include <string>

#include "trace.container.hpp"

using namespace SerializedTrace;

unsigned long int from;
unsigned long int until;


auto read_file(std::string path) -> std::string {
    constexpr auto read_size = std::size_t(4096);
    auto stream = std::ifstream(path.data());
    stream.exceptions(std::ios_base::badbit);
    
    auto out = std::string();
    auto buf = std::string(read_size, '\0');
    while (stream.read(& buf[0], read_size)) {
        out.append(buf, 0, stream.gcount());
    }
    out.append(buf, 0, stream.gcount());
    return out;
}

struct pair {
    bool ok;
    std::string start;
    std::string end;
};

void failed(int line) {
    std::cout << "failed to parse objdump; " << __FILE__ << ":" << line << std::endl;
    exit(1);
}

pair get_addrs(const std::string &filetext) {
    pair p;
    p.ok = false;
    auto end = std::string::npos;

    auto s = std::string("<main>:");
    auto main = filetext.find(s);
    if (main == end) failed(__LINE__);

    main += s.size();
    main = filetext.find_first_not_of(" \t\n\r", main);
    auto mainins = filetext.find(":", main);
    if (mainins == end) failed(__LINE__);
    p.start = filetext.substr(main, mainins - main);

    auto ret = filetext.find("ret", mainins);
    if (ret == end) failed(__LINE__);

    auto retlinestart = filetext.rfind("\n", ret);
    if (retlinestart == end) failed(__LINE__);
    retlinestart = filetext.find_first_not_of("\r\n\t ", retlinestart);

    auto retisn = filetext.find(":", retlinestart);
    if (retisn == end) failed(__LINE__);

    p.end = filetext.substr(retlinestart, retisn-retlinestart);
    p.ok = true;

    return p;
}

void copy_all(TraceContainerReader &r, TraceContainerWriter &w) {
  bool hit_start = from == 0;
  bool hit_end = false;

 while (!r.end_of_trace()) { 
     auto frame = r.get_frame();
     if (frame->has_std_frame()) {
         int addr = frame->std_frame().address();
         if (!hit_start) {
             if (addr == from) hit_start = true;
         } else {
             if (addr == until) { 
                 hit_end = true;
                 break;
             }
         } 
     }

     if (hit_start) w.add(*frame);
  }
     if (!hit_end && until != -1) std::cerr << "did not hit end address" << std::endl;

 if (!hit_start) {
    std::cerr << "Did not find start address :( " << std::endl;
    exit(1);
 }
}



int main(int argc, char **argv) {
    from = 0;
    until = -1;

    std::string srcfile;
    std::string destfile;
    std::string dump;
    int opt;
   bool src = false;
   bool dest = false;
   bool has_dump = false;

   std::string usage =  " usage: -i inputfile -o outputfile [-d objdumpfile|-f fromaddr -t toaddr]\n";

   while ((opt = getopt(argc, argv, "f:t:i:o:d:")) != -1) {
       switch (opt) {
       case 'i':
           src = true;
           srcfile = std::string(optarg);
           break;
       case 'o':
           dest = true;
           destfile = std::string(optarg);
           break;
       case 'f': 
           from = std::stoul(std::string(optarg), nullptr, 0);
           break;
        case 't':
           until = std::stoul(std::string(optarg),nullptr, 0);
           break;
        case 'd':
           dump = std::string(optarg);
           has_dump = true;
           break;
       default: /* '?' */
           std::cout << argv[0] << usage;
           exit(EXIT_FAILURE);
       }
   }

   if (!src || !dest) {
           std::cout << argv[0] << usage;
           exit(EXIT_FAILURE);
   }

   if ((from != 0) && has_dump) {
           std::cout << argv[0] << usage;
           exit(EXIT_FAILURE);
   }

   if (has_dump) {
       std::string dump_file = read_file(dump);

       auto limits = get_addrs(dump_file);
       if (!limits.ok) {
               std::cerr << argv[0] << "Failed to parse objdump\n";
               exit(EXIT_FAILURE);
       }

       from = std::stoul(limits.start,nullptr, 16);
       until = std::stoul(limits.end,nullptr, 16);
   }


   std::cerr << "copying frames with addresses from " << from << " until " << until << std::endl;

  TraceContainerReader r(srcfile);
  TraceContainerWriter w(destfile, *r.get_meta(), r.get_arch(), r.get_machine(), r.get_frames_per_toc_entry());

  copy_all(r, w);
  w.finish();
}
