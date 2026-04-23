import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/screens/bottom_navigation_screens/add_post_screen.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId=FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: ThemeManager.primaryBlue,
      title: const Text("My Posts",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      centerTitle: true,
      elevation: 0,
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts')
      .where('uid',isEqualTo:currentUserId)
      .orderBy('createdAt',descending: true)
      .snapshots(),
       builder: (context,snapshot){
        if (snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(color: ThemeManager.primaryBlue,),
          );
        }
        if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
          return Center(
             child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add_rounded,size:100,color:Colors.grey[300]),
                const SizedBox(height: 15,),
                Text(
                  "No posts yet!",
                  style: TextStyle(
                    color:Colors.grey[600],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8,),
                Text(
                  'Be the first to help the JUST community.',
                  style: TextStyle(color:Colors.grey[500],fontSize: 14),
                ),
              ],
             ),
          );
        }

        var docs=snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
          ),
          itemCount: docs.length,
          itemBuilder: (context,index){
            var data=docs[index].data() as Map<String,dynamic>;
            var docId=docs[index].id;
            return _buildPostCard(data,docId,context);
          }
          );
       }
       ),
    );
  }
  Widget _buildPostCard(Map<String,dynamic>data,String docId,BuildContext context){
    String imageURL=(data['images']!=null&&(data['images']as List).isNotEmpty)
    ? data['images'][0]
    : 'https://via.placeholder.com/150';

    bool isLost=data['status'] =='Lost';
    
    return Container(
      decoration: BoxDecoration(
        color:Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
                child:Image.network(
                  imageURL,
                  height: 120,
                  width: double.infinity,
                  fit:BoxFit.cover,
                  errorBuilder: (context,error,StackTrace)=>
                  Container(height: 120,color:Colors.grey[300],child: const Icon(Icons.broken_image),),

                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                    decoration: BoxDecoration(
                      color: isLost?Colors.red.withOpacity(0.9):Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),

                    ),
                    child: Text(
                      data["status"]??"Lost",
                      style: const TextStyle(color: Colors.white,fontSize: 10,fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(
                      data['title']??"Untitled",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color:ThemeManager.primaryBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                       icon: const Icon(Icons.more_horiz,size: 18,),
                        onSelected: (value){
                          if(value =='resolved'){
                            _markAsResolved(docId,context);
                          // }else if(value =='edit'){
                          //  _editPost(data,docId,context);
                           }else if(value=='delete'){
                           _deletePost(docId,context);
                          }
                        },

                      itemBuilder: (BuildContext context)=>[
                        const PopupMenuItem(
                          value: 'resolved',
                          child: ListTile(
                            leading: Icon(Icons.check_circle_outline,color: Colors.green,),
                            title: Text('Mark as resolved'),
                          ),
                          ),
                          const PopupMenuItem(
                         value: 'edit',
                         child: ListTile(
                        leading: Icon(Icons.edit, color: Colors.blue),
                        title: Text('Edit'),
                       ),
                      ),
                      const PopupMenuItem(
                       value: 'delete',
                      child: ListTile(
                       leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'),
      ),
    ),
                      ],
                      ),
                    

                  ],
                ),
                const SizedBox(height: 4,),
                Text(
                 data['description']??"No description available",
                 style: TextStyle(color:Colors.grey[700],fontSize: 11),
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 15,thickness: 0.5,),
                Row(
                  children: [
                    const Icon(Icons.location_on,size: 12,color:ThemeManager.primaryYellow),
                    const SizedBox(width: 4,),
                    Expanded(
                      child: Text(
                        data['location']??"JUST campus",
                        style:TextStyle(fontSize: 10,color:Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  ),
                  const SizedBox(height: 4,),

                  Row(
                    children: [
                      const Icon(Icons.category_rounded,size:12,color:ThemeManager.primaryBlue),
                      const SizedBox(height: 4,),
                      Text(
                        data['category']??"General",
                        style:TextStyle(fontSize: 10,color:Colors.grey[600],fontStyle: FontStyle.italic),
                      )
                    ],
                  ),

              ],
            ),),
        ],
      ),
    );

  }
  
  void _markAsResolved(String docId,BuildContext context) async{
   try {
     await FirebaseFirestore.instance.collection('posts').doc(docId).update({
     'isResolved': true,
      'status': 'Resolved'
     });
     if (context.mounted){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post marked as resolved!')));

     }
     
   } catch (e) {
     print("Error:$e");
   }

  }
//   void _editPost(Map<String, dynamic> data, String docId, BuildContext context) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => AddPost(
//         postData: data, 
//         postId: docId,
//       ),
//     ),
//   );
// }
  void _deletePost(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post deleted successfully"), backgroundColor: Colors.red));
      }
    } catch (e) {
      print("Error: $e");
    }
  }

}