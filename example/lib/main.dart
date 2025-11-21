import 'dart:convert';
import 'dart:io' as io show Directory, File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill_example/quill_delta_sample.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: HomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final QuillController _controller = () {
    return QuillController.basic(
        config: QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(
        enableExternalRichPaste: true,
        onImagePaste: (imageBytes) async {
          if (kIsWeb) {
            // Dart IO is unsupported on the web.
            return null;
          }
          // Save the image somewhere and return the image URL that will be
          // stored in the Quill Delta JSON (the document).
          final newFileName =
              'image-file-${DateTime.now().toIso8601String()}.png';
          final newPath = path.join(
            io.Directory.systemTemp.path,
            newFileName,
          );
          final file = await io.File(
            newPath,
          ).writeAsBytes(imageBytes, flush: true);
          return file.path;
        },
      ),
    ));
  }();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load document
    _controller.document = Document(); //.fromJson(kQuillDefaultSample);
  }

  void onPressed() {
    print("calling onPressed");
    int indexToInsert = _controller.selection.baseOffset;

    String imagePath =
        '/Users/chuang-chunliu/Library/Developer/CoreSimulator/Devices/66996CB4-D8E4-4429-A577-BB6BF4D763D2/data/Containers/Data/Application/E7CF92A0-5D5D-40BA-8878-D585B6DB3DA0/tmp/image_picker_85F3BEB0-DCA8-4CEB-9E6D-660AEE74D74C-8577-00000F64973BE4B5.jpg';
    _controller.document.insert(indexToInsert, BlockEmbed.image(imagePath));
    _controller.updateSelection(
        TextSelection.collapsed(offset: _controller.document.length),
        ChangeSource.local);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(onPressed: onPressed, child: const Text('do')),
            QuillSimpleToolbar(
              controller: _controller,
              config: QuillSimpleToolbarConfig(
                multiRowsDisplay: true,
                showDividers: false,
                showFontFamily: false,
                showFontSize: false,
                showBoldButton: false,
                showItalicButton: false,
                showLineHeightButton: false,
                showStrikeThrough: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: false,
                showAlignmentButtons: false,
                showHeaderStyle: false,
                showListNumbers: false,
                showListBullets: false,
                showListCheck: false,
                showCodeBlock: false,
                showQuote: false,
                showIndent: false,
                showLink: false,
                showUndo: false,
                showRedo: false,
                showDirection: false,
                showSearchButton: false,
                showSmallButton: false,
                showSubscript: false,
                showSuperscript: false,
                showClipboardCut: false,
                showClipboardCopy: false,
                showClipboardPaste: false,
                showUnderLineButton: false,
                embedButtons: FlutterQuillEmbeds.toolbarButtons(
                    imageButtonOptions: QuillToolbarImageButtonOptions(),
                    videoButtonOptions: null),
              ),
            ),
            Expanded(
              child: QuillEditor(
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
                controller: _controller,
                config: QuillEditorConfig(
                  placeholder: 'Start writing your notes...',
                  padding: const EdgeInsets.all(16),
                  embedBuilders: [
                    ...FlutterQuillEmbeds.editorBuilders(
                      imageEmbedConfig: QuillEditorImageEmbedConfig(
                          imageProviderBuilder: (context, imageUrl) {
                        // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                        print("**** file image $imageUrl");
                        return Image(
                                image: ResizeImage(FileImage(File(imageUrl)),
                                    width: 12, height: 100))
                            .image;
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
    String value,
  ) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}
