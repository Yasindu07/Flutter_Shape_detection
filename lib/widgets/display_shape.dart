import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shape_detection/model/shape_model.dart';
import 'package:shape_detection/services/database_service.dart';

class DisplayShapes extends StatefulWidget {
  const DisplayShapes({super.key});

  @override
  State<DisplayShapes> createState() => _DisplayShapesState();
}

class _DisplayShapesState extends State<DisplayShapes> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ShapeModel>>(
      stream: _databaseService.shapes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ShapeModel> shapes = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: shapes.length,
            itemBuilder: (context, index) {
              final DateTime dt = shapes[index].timestamp.toDate();
              return Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Slidable(
                  startActionPane: ActionPane(
                    motion: DrawerMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                        onPressed: (context) {
                          _showAddShapeDialog(context, shape: shapes[index]);
                        },
                      ),
                      SlidableAction(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                        onPressed: (context) async {
                          await _databaseService
                              .deleteShape(shapes[index].shapeId);
                        },
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      shapes[index].shapeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      '${dt.day}/${dt.month}/${dt.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      },
    );
  }

  void _showAddShapeDialog(BuildContext context, {ShapeModel? shape}) {
    final TextEditingController _shapeNameController =
        TextEditingController(text: shape?.shapeName);
    final DatabaseService _databaseService = DatabaseService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Shape'),
          content: TextField(
            controller: _shapeNameController,
            decoration: const InputDecoration(
              hintText: 'Enter shape name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (shape != null) {
                  await _databaseService.updateShape(
                    shape.shapeId,
                    _shapeNameController.text,
                  );
                } else {
                  await _databaseService.saveShape(_shapeNameController.text);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
