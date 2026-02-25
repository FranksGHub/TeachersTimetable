import '../models/lesson_block.dart';
import '../models/export_import_files.dart';

class FilenameHelper {

  static String getDefaultLeftFilename(LessonBlock block, bool withJsonExtension) { 
    return ExportImportFiles.GetSaveFilename('${block.lessonName}_${block.className}_${block.schoolName}' + (withJsonExtension ? '.json' : ''));
  }

  static String getDefaultRightFilename(LessonBlock block, bool withJsonExtension) { 
    return ExportImportFiles.GetSaveFilename('_${block.lessonName}' + (withJsonExtension ? '.json' : ''));
  }

  static String getDefaultNotesFilename(int coloumn, bool withJsonExtension) { 
    return ExportImportFiles.GetSaveFilename('notes_col_${coloumn}' + (withJsonExtension ? '.json' : ''));
  }

}