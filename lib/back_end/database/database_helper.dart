// ignore_for_file: avoid_void_async

import "package:flutter/foundation.dart";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";

final class DatabaseHelper {
  static Database? database;

  static Future<void> init() async {
    String databasesPath = join(await getDatabasesPath(), "database.db");

    database = await openDatabase(
      databasesPath,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute("PRAGMA foreign_keys = ON");
        await db.transaction((Transaction tx) async {
          await tx.execute(""
              "CREATE TABLE IF NOT EXISTS task_lists ( "
              "id INTEGER PRIMARY KEY, "
              "name TEXT NOT NULL, "
              "list_index INTEGER NOT NULL "
              ")");
          await tx.execute(""
              "CREATE TABLE IF NOT EXISTS tasks ( "
              "id INTEGER PRIMARY KEY, "
              "list_id INTEGER NOT NULL, "
              "name TEXT NOT NULL, "
              "deadline INTEGER, "
              "is_completed INTEGER NOT NULL, "
              "list_index INTEGER NOT NULL, "
              "FOREIGN KEY(list_id) REFERENCES task_lists(id) "
              ")");
        });
      },
    );
  }

  static Future<void> registerRepository(TaskRepository repository) async {
    if (await taskLists case List<TaskList> taskLists) {
      repository.registerTaskLists(taskLists);
    }

    if (await tasks case List<Task> tasks) {
      repository.registerTasks(tasks);
    }
  }

  static Future<List<Task>?> get tasks async {
    if (database case Database database) {
      List<Map<String, dynamic>> maps = await database.query("tasks");
      List<Task> tasks = <Task>[
        for (var {
              "id": int id,
              "list_id": int listId,
              "name": String title,
              "deadline": int? deadline,
              "is_completed": int isCompleted,
              "list_index": int listIndex,
            } in maps) //
          Task(
            title: title,
            id: id,
            listId: listId,
            isCompleted: isCompleted == 1,
            deadline: deadline != null ? DateTime.fromMillisecondsSinceEpoch(deadline) : null,
            listIndex: listIndex,
          ),
      ];

      return tasks;
    }

    if (kDebugMode) {
      print("[DatabaseHelper.tasks] The database was not initialized. ${DateTime.now()}");
    }
    return null;
  }

  static Future<List<TaskList>?> get taskLists async {
    if (database case Database database) {
      List<Map<String, dynamic>> maps = await database.query("task_lists");
      List<TaskList> taskLists = <TaskList>[
        for (var {"id": int id, "name": String name, "list_index": int listIndex} in maps) //
          TaskList(id: id, name: name, listIndex: listIndex),
      ];

      return taskLists;
    }

    if (kDebugMode) {
      print("[DatabaseHelper.taskLists] The database was not initialized. ${DateTime.now()}");
    }
    return null;
  }

  static void addTaskList(TaskList taskList) async {
    if (database case Database database) {
      print(await database.insert("task_lists", taskList.toMap()));
    }
  }

  static void removeTaskList(TaskList taskList) async {
    if (database case Database database) {
      await database.transaction((Transaction tx) async {
        await tx.delete("task_lists", where: "id = ?", whereArgs: <Object?>[taskList.id]);
        await tx.delete("tasks", where: "list_id = ?", whereArgs: <Object?>[taskList.id]);
      });
    }
  }

  static void renameTaskList({required int id, required String name}) async {
    if (database case Database database) {
      await database.update("task_lists", <String, Object?>{"name": name}, where: "id = ?", whereArgs: <Object?>[id]);
    }
  }

  static void setTaskListListIndex({required int id, required int listIndex}) async {
    if (database case Database database) {
      await database.update(
        "task_lists",
        <String, Object?>{"list_index": listIndex},
        where: "id = ?",
        whereArgs: <Object?>[id],
      );
    }
  }

  static void addTask(Task task) async {
    if (database case Database database) {
      await database.insert("tasks", task.toMap());
    }
  }

  static void removeTask(Task task) async {
    if (database case Database database) {
      await database.delete("tasks", where: "id = ?", whereArgs: <Object?>[task.id]);
    }
  }

  static void setTaskName(Task task, {required String name}) async {
    if (database case Database database) {
      await database.update(
        "tasks",
        <String, Object?>{"name": name},
        where: "id = ?",
        whereArgs: <Object?>[task.id],
      );
    }
  }

  static void setTaskCompleted(Task task, {required bool isCompleted}) async {
    if (database case Database database) {
      await database.update(
        "tasks",
        <String, Object?>{"is_completed": isCompleted ? 1 : 0},
        where: "id = ?",
        whereArgs: <Object?>[task.id],
      );
    }
  }

  static void setTaskDeadline(Task task, {required DateTime? deadline}) async {
    if (database case Database database) {
      await database.update(
        "tasks",
        <String, Object?>{"deadline": deadline?.millisecondsSinceEpoch},
        where: "id = ?",
        whereArgs: <Object?>[task.id],
      );
    }
  }

  static void setTaskListId(Task task, {required int listId}) async {
    if (database case Database database) {
      await database.update(
        "tasks",
        <String, Object?>{"list_id": listId},
        where: "id = ?",
        whereArgs: <Object?>[task.id],
      );
    }
  }

  static void setTaskListIndex(Task task, {required int listIndex}) async {
    if (database case Database database) {
      await database.update(
        "tasks",
        <String, Object?>{"list_index": listIndex},
        where: "id = ?",
        whereArgs: <Object?>[task.id],
      );
    }
  }
}
