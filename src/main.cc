#include "data.pb.h"
#include "injector.h"

Session* create_session(int argc, char** argv);

int main(int argc, char** argv) {
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  std::setlocale(LC_NUMERIC, "");

  Session* const session = create_session(argc, argv);

  google::protobuf::ShutdownProtobufLibrary();

  return 0;
}

Session* create_session(int argc, char** argv) {
  // Initialize parallel.
  Parallel* const parallel = Injector::new_parallel(argc, argv);

  // Initialize timer.
  Timer* const timer = Injector::new_timer(parallel);
  timer->init();

  // Initialize config.
  timer->start("Loading configuration");
  Config* const config = Injector::new_config("config.json", parallel);
  timer->end();

  // Initialize session.
  Session* const session = Injector::new_session(parallel, config, timer);

  return session;
}