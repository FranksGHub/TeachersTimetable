import '../models/lesson_block.dart';
import '../models/export_import_files.dart';

class FilenameHelper {

  static String getDefaultLeftFilename(LessonBlock block, bool withJsonExtension) { 
    return ExportImportFiles.getSaveFilename('${block.lessonName}_${block.className}_${block.schoolName}' + (withJsonExtension ? '.json' : ''));
  }

  static String getDefaultRightFilename(LessonBlock block, bool withJsonExtension) { 
    return ExportImportFiles.getSaveFilename('_${block.lessonName}' + (withJsonExtension ? '.json' : ''));
  }

  static String getDefaultNotesFilename(int column, bool withJsonExtension) { 
    final int col = column +1;
    return ExportImportFiles.getSaveFilename('notes_col_${col}' + (withJsonExtension ? '.json' : ''));
  }

}