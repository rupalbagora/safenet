// jo module express and mongodb ke bich connectivity ka km krega usko mongoose module bolte h
// we have to install mongoose module - open cmd in api folder and run - npm install mongoose

import mongoose from 'mongoose';
// connection string - jo mongodb se connect kre
           // 'mongodb://localhost:27017/database_name'
// const url = 'mongodb://localhost:27017/mernbatchtraining'  //default port of mongodb=27017

//agr localhost na chle toh local ip dal do
//localip 127.0.0.1
const url = 'mongodb://127.0.0.1:27017/mernbatchtraining7apr';


mongoose.connect(url);

console.log("Database connect successfully")
