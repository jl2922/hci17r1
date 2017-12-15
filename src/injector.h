#ifndef INJECTOR_H_
#define INJECTOR_H_

#include "session.h"

// Dependency injection.
class Injector {
 public:
  static Session* new_session(
      Parallel* const parallel, Config* const config, Timer* const timer);

  static Parallel* new_parallel(int argc, char** argv);

  static Config* new_config(
      const std::string& filename, Parallel* const parallel);

  static Timer* new_timer(Parallel* const parallel);
};

#endif
