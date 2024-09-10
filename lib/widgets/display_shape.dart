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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Objects'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<List<ShapeModel>>(
          stream: _databaseService.shapes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<ShapeModel> shapes = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shapes.length,
                itemBuilder: (context, index) {
                  final shape = shapes[index];
                  final DateTime dt = shape.timestamp.toDate();
                  return Container(
                    width: double.infinity,
                    height: 120,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Slidable(
                      startActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                            onPressed: (context) {
                              _showAddShapeDialog(context, shape: shape);
                            },
                          ),
                          SlidableAction(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            onPressed: (context) async {
                              await _databaseService.deleteShape(shape.shapeId);
                            },
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: shape.imageUrl.isNotEmpty
                            ? Image.network(
                                shape.imageUrl,
                                width: 100,
                                height: 150,
                                fit: BoxFit.fitWidth,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey,
                              ), // Placeholder if no image
                        title: Text(
                          shape.shapeName,
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
        ),
      ),
    );
  }

  void _showAddShapeDialog(BuildContext context, {ShapeModel? shape}) {
    final TextEditingController _shapeNameController =
        TextEditingController(text: shape?.shapeName);
    final TextEditingController _imageUrlController =
        TextEditingController(text: shape?.imageUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detected Shape'),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  TextField(
                    controller: _shapeNameController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  // TextField(
                  //   controller: _imageUrlController,
                  //   decoration: const InputDecoration(
                  //     hintText: 'Enter image URL',
                  //   ),
                  // ),
                ],
              ),
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
                  await _databaseService.saveShape(
                    _shapeNameController.text,
                    _imageUrlController.text,
                  );
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
