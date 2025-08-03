/// @docImport 'package:analyzer/dart/element/element.dart';
/// @docImport 'package:meta/meta_meta.dart';
library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation_generator.dart';
import 'composed_generator.dart';
import 'generate_annotation.dart';

class AnnotationsBuilder extends RecursiveAnnotationGenerator {
  const AnnotationsBuilder(this.generators, {super.throwOnUnresolved});

  @override
  final Iterable<GenerateOnAnnotationBase<dynamic>> generators;
}

class PartAnnotationsBuilder extends AnnotationsBuilder with PartGenerator {
  const PartAnnotationsBuilder(super.generators, {super.throwOnUnresolved});
}

class LibraryAnnotationBuilder extends AnnotationsBuilder {
  const LibraryAnnotationBuilder(
    super.generators, {
    this.imports = const [],
    this.prefixComments = const [],
    super.throwOnUnresolved,
  });

  final Iterable<String> imports;
  final Iterable<String> prefixComments;

  @override
  String? generate(LibraryReader library, BuildStep buildStep) {
    final String? result = super.generate(library, buildStep);
    if (result == null) return null;
    final List<String> sortedImports = imports.toList()..sort();
    final Iterable<String> lines = sortedImports.map((i) => "import '$i';");
    final String prefix = prefixComments.map((line) => '// $line').join('\n');
    return '$prefix\n\n${lines.join('\n')}\n\n$result';
  }
}
