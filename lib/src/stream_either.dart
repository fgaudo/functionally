import 'dart:async';

import 'common.dart';
import 'either.dart';
import 'either.dart' as E;

typedef StreamEither<L, R> = Stream<Either<L, R>>;

StreamEither<L2, R2> Function(
  StreamEither<L1, R1> either$,
) bimap<L1, L2, R1, R2>({
  required L2 Function(L1) left,
  required R2 Function(R1) right,
}) =>
    match(
      left: (value) => Left(left(value)),
      right: (value) => Right(right(value)),
    );

StreamEither<L2, R> Function<R>(
  StreamEither<L1, R> either$,
) mapLeft<L1, L2>(
  L2 Function(L1) left,
) =>
    <R>(either$) => bimap(
          left: left,
          right: identity<R>,
        )(either$);

StreamEither<L, R2> Function<L>(
  StreamEither<L, R1> either$,
) map<R1, R2>(
  R2 Function(R1) right,
) =>
    <L>(either$) => bimap(
          left: identity<L>,
          right: right,
        )(either$);

Stream<A> Function(
  StreamEither<L, R> either$,
) match<A, L, R>({
  required A Function(L) left,
  required A Function(R) right,
}) =>
    (either$) => either$.map(
          E.match(
            left: left,
            right: right,
          ),
        );
