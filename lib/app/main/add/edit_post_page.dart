import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_sns/app/main/models/post.dart';
import 'package:simple_sns/common_widgets/platform_alert_dialog.dart';
import 'package:simple_sns/services/database.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({
    Key key,
    @required this.database,
    @required this.post,
  }) : super(key: key);

  final Database database;
  final Post post;

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();

  String _title;
  String _body;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _title = widget.post.title;
      _body = widget.post.body;
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit(Database database) async {
    if (_validateAndSaveForm()) {
      final id = widget.post.id ?? documentIdFromCurrentDate();
      final post = Post(id: id, title: _title, body: _body);
      await database.setPost(post);
      try {
        final dynamic resp = await CloudFunctions.instance.getHttpsCallable(
            functionName: 'onUsersPostUpdate').call();
        print(resp);
      } on CloudFunctionsException catch (e) {
        print("caught firebase functions exception: $e");
      } catch (e) {
        print("caught generic exception: $e");
      }
      Navigator.of(context).pop();
    } else {
      PlatformAlertDialog(
        title: 'Title or Body is null',
        content: 'Please write something',
        defaultActionText: 'OK',
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: Text("Edit post"),
        actions: <Widget>[
          FlatButton(
            child: Text("Save", style: TextStyle(fontSize: 18, color: Colors.white),),
            onPressed: () => _submit(database),
          )
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        keyboardType: TextInputType.text,
        initialValue: _title,
        decoration: InputDecoration(labelText: 'Title'),
        validator: (value) => value.isNotEmpty ? null : 'Title can\'t be empty',
        onSaved: (value) => _title = value,
      ),
      SizedBox(height: 8,),
      TextFormField(
        keyboardType: TextInputType.multiline,
        initialValue: _body,
        maxLines: _body.length ~/ 10 + 1, // 動的に変えたい
        decoration: InputDecoration(labelText: 'Body'),
        validator: (value) => value.isNotEmpty ? null : 'Body can\'t be empty',
        onSaved: (value) => _body = value,
      ),
    ];
  }
}
