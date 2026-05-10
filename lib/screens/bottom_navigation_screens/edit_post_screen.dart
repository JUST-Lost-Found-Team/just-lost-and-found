import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/helpers/explore_options.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class EditPostScreen extends StatefulWidget {
  final Map<String,dynamic>postData;
  final String postId;
  const EditPostScreen({super.key,required this.postData,required this.postId});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey=GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late bool _isLost;
  String? _selectedCategory;
  String? _selectedLocation;
  bool _isLoading=false;
  final Color _fillColor=Colors.grey.shade200;

  @override
  void initState(){
    super.initState();
    _titleController=TextEditingController(text:widget.postData['title']);
    _descController=TextEditingController(text:widget.postData['description']);
    _selectedCategory=Categories.categories.contains(widget.postData['category'])
    ?widget.postData['category']
    :null;
    _selectedLocation = LocationData.locations.contains(widget.postData['location']) 
      ? widget.postData['location'] 
      : null;
    _isLost=widget.postData['status']=='Lost';
    
  }
  Future<void>_updatePost()async{
    if(!_formKey.currentState!.validate())return;
    setState(()=>_isLoading=true);
  
  try{
    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
      'title':_titleController.text.trim(),
      'description':_descController.text.trim(),
      'location':_selectedLocation,
      'category':_selectedCategory,
      'status':_isLost?'Lost':'Found',
    });
    if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post updated successfully!'),
      backgroundColor: ThemeManager.successGreen,),
    );
    Navigator.pop(context);
    }
  }catch(e){
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update failed:$e'),backgroundColor: ThemeManager.errorRed,),

      );
    }
  }finally{
    if(mounted)setState(()=>_isLoading=false);
   
  }

      

  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryBlue,
        title: Text('Edit Post',style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key:_formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Title:"),
              _buildTextField(controller:_titleController,hint:"Title of the item..."),
              const SizedBox(height: 16,),
              _buildSectionTitle("Description:"),
              _buildTextField(controller:_descController,hint:"Description of the item...",maxLines:4),
              const SizedBox(height:16),
              _buildSectionTitle("Location:"),
              _buildDropdown(
                hint:"Select Campus Location...",
                value:_selectedLocation,
                items: LocationData.locations
                    .map(
                      (item) => DropdownMenuItem<String>(
                        
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedLocation = val),
              ),
              const SizedBox(height: 16,),
              _buildSectionTitle("Category:"),
              _buildDropdown(
                hint: "Select Item Category...",
                value: _selectedCategory,
                items: Categories.categories
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
               const SizedBox(height: 20,),
               _buildStatusSwitch(),
               const SizedBox(height: 30,),
               SizedBox(
                width: double.infinity,
                height:55,
                child: ElevatedButton(
                  onPressed:_isLoading?null:_updatePost,
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeManager.primaryBlue,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),

                   child: _isLoading
                   ?const CircularProgressIndicator(color:Colors.white)
                   :const Text("Update post",style:TextStyle(color:Colors.white,fontSize: 18,fontWeight: FontWeight.bold)),
                   ),
               ),
            ],
              
          ),
      
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title)=>Padding(
    padding: const EdgeInsets.only(bottom:0.8),
    child:Text(title,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),);

    Widget _buildTextField({required TextEditingController controller,required String hint,int maxLines=1}){
      return TextFormField(
        controller:controller,
        maxLines: maxLines,
        validator: (v)=>v!.isEmpty ?"Required":null,
        decoration: InputDecoration(filled: true,fillColor: _fillColor,hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
      );
    }
    Widget _buildDropdown({required String hint,required String? value,required List<DropdownMenuItem<String>>items,required Function(String?) onChanged}){
      return DropdownButtonFormField<String>(
        value:value,
        items: items,
         onChanged: onChanged,
         isExpanded: true,
         alignment: AlignmentDirectional.bottomStart,
         menuMaxHeight: 350,
         borderRadius: BorderRadius.circular(15),
    decoration: InputDecoration(
      filled: true,
      fillColor: _fillColor,
      
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
         
        // decoration: InputDecoration(filled: true,fillColor: _fillColor,border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide.none)),
         );
    }
    Widget _buildStatusSwitch(){
      return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _fillColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Item Status", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text("Lost", style: TextStyle(color: _isLost ? Colors.black : Colors.grey)),
              Switch(
                value: !_isLost,
                onChanged: (v) => setState(() => _isLost = !v),
                activeColor: ThemeManager.primaryYellow,
              ),
              Text("Found", style: TextStyle(color: !_isLost ? Colors.black : Colors.grey)),
            ],
          ),
        ],
      ),
    );
    }
}
