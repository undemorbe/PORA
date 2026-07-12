import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class ImageProcessingService {
  // ignore: non_constant_identifier_names
  static Future<File?>? RepublicImageProcess(File pickedFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Resize",
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Resize',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile == null) return null;

    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.webp';

    final compressedXFile = await FlutterImageCompress.compressAndGetFile(
      croppedFile.path,
      targetPath,
      format: CompressFormat.webp,
      minWidth: 500,
      minHeight: 500,
      quality: 85,
    );

    if (compressedXFile == null) return null;

    return File(compressedXFile.path);
  }
}
