import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:meta/meta_meta.dart';
import 'package:source_gen/source_gen.dart';

/// Define how to generate data according to an annotation of type [T].
///
/// Override the [build] method to define
/// how to build on an parsed element annotated with an annotation of type [T].
/// When there's multiple annotation with the same specified type [T],
/// or match the override [typeChecker] rule, it will only use the first one.
abstract class GenerateOnAnnotationBase<T> {
  const GenerateOnAnnotationBase();

  /// Define how to check the type [T].
  TypeChecker get typeChecker => TypeChecker.fromRuntime(T);

  /// How to build on a single annotation of type [T].
  String build(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  );

  /// Check type and build when necessary.
  ///
  /// 1. When there's multiple annotation with the same specified type [T],
  /// or match the override [typeChecker] rule, it will only use the first one.
  /// 2. When there's nothing to build, it will return null.
  /// 3. It's strongly not recommended to override this method directly.
  /// You may consider override the [build] method or the [typeChecker] getter.
  String? maybeBuild(
    Element2 element,
    BuildStep buildStep, {
    bool throwOnUnresolved = true,
  }) {
    final DartObject? result = typeChecker.firstAnnotationOf(
      element,
      throwOnUnresolved: throwOnUnresolved,
    );
    if (result == null) return null;
    return build(element, ConstantReader(result), buildStep);
  }
}

/// Like [GenerateOnAnnotationBase], but ensure [build] implemented
/// by throwing [AnnotationPositionException] by default.
/// Override and call super to specify corresponding building logics.
abstract class GenerateOnAnnotation<T> extends GenerateOnAnnotationBase<T> {
  const GenerateOnAnnotation();

  @override
  String build(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => throw AnnotationPositionException<T>();
}

/// Throw when the annotation position is invalid.
///
/// The valid position of an annotation should be indicated by the [Target]
/// annotation provided by `package:meta`.
/// And it is supposed to be check before using the parsed [Element2]
/// and assert the type of the source element.
class AnnotationPositionException<T> implements Exception {
  const AnnotationPositionException();

  @override
  String toString() => 'invalid annotation position of $T';
}
