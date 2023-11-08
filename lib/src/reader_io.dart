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

ReaderIO<ENV2, A> Function<A>(ReaderIO<ENV1, A>) local<ENV1, ENV2>(
  ENV1 Function(ENV2) f,
) =>
    <A>(rio) => (env2) => rio(f(env2));

ReaderIO<ENV, A> asks<ENV, A>(
  A Function(ENV) f,
) =>
    (env) {
      final a = f(env);
      return () => a;
    };

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