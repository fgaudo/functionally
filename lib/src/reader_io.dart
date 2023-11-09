import '../io.dart' as I;
import '../reader.dart' as R;

typedef ReaderIO<ENV, A> = R.Reader<ENV, I.IO<A>>;

ReaderIO<ENV, B> Function<ENV>(ReaderIO<ENV, A>) flatMapIO<A, B>(
  I.IO<B> Function(A) f,
) =>
    <ENV>(ra) => (r) {
          final f2 = ra(r);
          return () => f(f2())();
        };

ReaderIO<ENV, B> Function(ReaderIO<ENV, A>) flatMap<ENV, A, B>(
  ReaderIO<ENV, B> Function(A) f,
) =>
    (ra) => (r) {
          final f2 = ra(r);
          return () => f(f2())(r)();
        };

ReaderIO<ENV, B> Function<ENV>(ReaderIO<ENV, A>) map<A, B>(
  B Function(A) f,
) =>
    <ENV>(ra) => (r) {
          final f2 = ra(r);
          return () => f(f2());
        };

ReaderIO<ENV, ENV2> asks<ENV, ENV2>(
  R.Reader<ENV, ENV2> f,
) =>
    (env) {
      final a = f(env);
      return () => a;
    };

ReaderIO<ENV, ENV> ask<ENV>() => (env) => () => env;

ReaderIO<ENV, A> asksReaderIO<ENV, A>(
  ReaderIO<ENV, A> f,
) =>
    (env) => f(env);

ReaderIO<ENV, B> Function(ReaderIO<ENV, A>) bracket<ENV, A, B>({
  required ReaderIO<ENV, void> Function(A) release,
  required ReaderIO<ENV, B> Function(A) use,
}) =>
    (acquire) => (env) {
          final acquireF = acquire(env);
          return () {
            final resource = acquireF();
            try {
              return use(resource)(env)();
            } finally {
              release(resource)(env)();
            }
          };
        };

ReaderIO<R, void> Do<R>() => (_) => () {};

ReaderIO<R, Iterable<A>> sequenceArray<R, A>(Iterable<ReaderIO<R, A>> arr) =>
    (env) => () => arr.map((io) => io(env)());
