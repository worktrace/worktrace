import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'composed_generator.dart';
import 'generate_annotation.dart';

abstract class ComposedAnnotationGenerator extends ComposedGenerator {
  const ComposedAnnotationGenerator({this.throwOnUnresolved = true});

  final bool throwOnUnresolved;

  Iterable<GenerateOnAnnotationBase<dynamic>> get generators;
}

abstract class TopLevelAnnotationGenerator extends ComposedAnnotationGenerator {
  const TopLevelAnnotationGenerator({super.throwOnUnresolved});

  @override
  Iterable<String> generateComponents(
    LibraryReader library,
    BuildStep buildStep,
  ) sync* {
    for (final Element2 element in library.allElements) {
      for (final GenerateOnAnnotationBase generator in generators) {
        final String? result = generator.maybeBuild(
          element,
          buildStep,
          throwOnUnresolved: throwOnUnresolved,
        );
        if (result != null) yield result;
      }
    }
  }
}

/// Generate recursively from multiple [GenerateOnAnnotation]s.
///
/// If your generating strategy is simple enough and works like
/// the raw [GeneratorForAnnotation],
/// you may consider [TopLevelAnnotationGenerator], which is more efficient.
/// This generator will recursively process all children elements of a library.
abstract class RecursiveAnnotationGenerator
    extends ComposedAnnotationGenerator {
  const RecursiveAnnotationGenerator({super.throwOnUnresolved});

  @override
  Iterable<String> generateComponents(
    LibraryReader library,
    BuildStep buildStep,
  ) => generateRootElement(
    library.element,
    buildStep,
    throwOnUnresolved: throwOnUnresolved,
  );

  /// Generate code recursively based on the root [element] of a library.
  ///
  /// The root [element] is supposed to be at the root of a library
  /// (from a [LibraryReader]).
  /// The annotation of the [element] itself will not be recognized here.
  /// It will only process the children layer, and recursive when necessary.
  @protected
  Iterable<String> generateRootElement(
    Element2 element,
    BuildStep buildStep, {
    bool throwOnUnresolved = true,
  }) sync* {
    for (final Element2 child in element.children2) {
      for (final GenerateOnAnnotationBase generator in generators) {
        final String? result = generator.maybeBuild(
          child,
          buildStep,
          throwOnUnresolved: throwOnUnresolved,
        );
        if (result != null) yield result;
      }
      yield* generateRootElement(
        child,
        buildStep,
        throwOnUnresolved: throwOnUnresolved,
      );
    }
  }
}
