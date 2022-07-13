// ignore_for_file: no_logic_in_create_state, implementation_imports, prefer_typing_uninitialized_variables, prefer_const_constructors, no_leading_underscores_for_local_identifiers
//@dart=2.9
import 'package:chat_application/chatting_page.dart';
import 'package:flutter/material.dart';

class SearchUsers extends StatefulWidget {
  final usersList, roomId;
  const SearchUsers({Key key, this.usersList, this.roomId}) : super(key: key);

  @override
  State<SearchUsers> createState() => _SearchUsersState(usersList, roomId);
}

class _SearchUsersState extends State<SearchUsers> {
  final searchController = TextEditingController();
  var usersList, roomId, usersFiltered = [];
  _SearchUsersState(this.usersList, this.roomId);

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      filteredUsersList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 11, 0),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_sharp)),
        title: Container(
          width: 250,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: IntrinsicWidth(
              child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: TextField(
              controller: searchController,
              cursorHeight: 22,
              autofocus: true,
              cursorColor: Color.fromARGB(255, 52, 11, 0),
              decoration:
                  InputDecoration(border: InputBorder.none, hintText: "search"),
            ),
          )),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              "Suggested",
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: (searchController.text.isEmpty)
                      ? usersList.length
                      : usersFiltered.length,
                  itemBuilder: (context, i) {
                    var x = (searchController.text.isEmpty)
                        ? usersList[i]
                        : usersFiltered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        // ignore: sort_child_properties_last
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        backgroundColor: Color.fromARGB(255, 52, 11, 0),
                      ),
                      title: Text(
                        x['Name'],
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ChatScreen(
                            chatRoomId: roomId,
                            userInfo: x,
                          );
                        }));
                      },
                    );
                  })),
        ],
      ),
    );
  }

  void filteredUsersList() {
    List _users = [];
    _users.addAll(usersList);
    if (searchController.text.isNotEmpty) {
      setState(() {
        _users.retainWhere((user) {
          String searchTerm = searchController.text.toLowerCase();
          String userName = user['Name'].toString().toLowerCase();
          return userName.contains(searchTerm);
        });
        usersFiltered = _users;
      });
    } else {
      setState(() {
        usersFiltered.clear();
      });
    }
  }
}
