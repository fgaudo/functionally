import '../reader.dart' as R;
import '../reader_io.dart' as RIO;
import '../task.dart' as T;

typedef ReaderTask<ENV, A> = R.Reader<ENV, T.Task<A>>;

// Constructors

ReaderTask<ENV, void> make<ENV>() => (_) => () async {};
ReaderTask<ENV, ENV> ask<ENV>() => (env) => () async => env;

ReaderTask<ENV1, ENV2> asks<ENV1, ENV2>(
  ENV2 Function(ENV1) f,
) =>
    (env1) {
      final env2 = f(env1);
      return () async => env2;
    };

// Helpers

ReaderTask<ENV, A> fromReaderIO<ENV, A>(RIO.ReaderIO<ENV, A> rio) =>
    (env) => () async => rio(env)();

ReaderTask<ENV, B> Function<ENV>(ReaderTask<ENV, A>) map<A, B>(
  B Function(A) f,
) =>
    <ENV>(rt) => (env) {
          final task = rt(env);
          return () async => f(await task());
        };

ReaderTask<ENV, B> Function(ReaderTask<ENV, A>) map_<ENV, A, B>(
  B Function(A) f,
) =>
    map(f);

ReaderTask<ENV, B> Function(ReaderTask<ENV, A>) flatMap<ENV, A, B>(
  ReaderTask<ENV, B> Function(A) f,
) =>
    (rt) => (env) {
          final task = rt(env);
          return () async => f(await task())(env)();
        };

ReaderTask<ENV, B> Function<ENV>(ReaderTask<ENV, A>) flatMapTask<A, B>(
  T.Task<B> Function(A) f,
) =>
    <ENV>(rt) => (env) {
          final task = rt(env);
          return () async => f(await task())();
        };

ReaderTask<ENV, B> Function(ReaderTask<ENV, A>) flatMapTask_<ENV, A, B>(
  T.Task<B> Function(A) f,
) =>
    flatMapTask_(f);

ReaderTask<ENV, Iterable<A>> sequenceArray<ENV, A>(
  Iterable<ReaderTask<ENV, A>> arr,
) =>
    (env) => () => Future.wait(
          arr.map(
            (rt) => rt(env)(),
          ),
        );

ReaderTask<ENV2, A> Function<A>(ReaderTask<ENV1, A>) local<ENV1, ENV2>(
  ENV1 Function(ENV2) f,
) =>
    <A>(r) => (env2) => r(f(env2));

ReaderTask<ENV2, A> Function(ReaderTask<ENV1, A>) local_<A, ENV1, ENV2>(
  ENV1 Function(ENV2) f,
) =>
    local(f);
