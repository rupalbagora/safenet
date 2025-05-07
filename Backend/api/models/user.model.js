//this is a schema file
import mongoose from "mongoose";
//unique values hi accept kre koi fiedls iske liye module install krna pdega - npm install mongoose-unique-validator@5.0.0
import mongooseUniqueValidator from 'mongoose-unique-validator'

//backend se aane wali key ka nam and schema ki key ka nam same hona chahiye
const userSchema=mongoose.Schema({
    _id:Number,
    name:{
        type:String,
        require:[true,'name is required'],
        trim:true, //unwanted space ko htayega aage aur piche se
        lowercase:true,

    },
    email:{
        type:String,
        require:[true,'email is required'],
        trim:true, //unwanted space ko htayega aage aur piche se
        lowercase:true,
        unique:true

    },
    aadhar_no:{
        type:String,
        require:[true,'aadhar is required'],
        trim:true, //unwanted space ko htayega aage aur piche se
        lowercase:true,
        minlength:12,
        maxlength:12
    },
    password:{
        type:String,
        require:[true,'password is required'],
        trim:true, //unwanted space ko htayega aage aur piche se
        maxlength:10,
        minlength:5

    },
    mobile:{
        type:Number,
        require:[true,'mobile is required'],
        trim:true, //unwanted space ko htayega aage aur piche se
        maxlength:10,
    },
    location: {
    latitude: { type: Number },
    longitude: { type: Number },
    timestamp: { type: Date, default: Date.now }
  },
 
    // gender:{
    //     type:String,
    //     require:[true,'gender is required'],
        
      
    // },
    role:String,
    status:Number,
    info:String

}); //to create schema- it take object and schema will return instance of schema

//mongooseUniqueValidator ko active krna pdhta h jisko plugin ki help se krenge
//to apply unique validator
mongoose.plugin(mongooseUniqueValidator);

// mongoose.model('collection_name',jo instance pass krna h vo ayega)
const userSchemaModel=mongoose.model('user_collection',userSchema);
export default userSchemaModel; // ab is file ko controller pr link kro