import express from 'express';

//to check upcoming request
//data body ke sth aa rha h toh us data ko parse ya extract krne ke liye ek module ki jrurat hotu h called body parser (npm install body-parser)
import bodyParser from 'body-parser';
import cors from 'cors'
import { networkInterfaces } from 'os';
import { writeFileSync } from 'fs';

const app=express();
//to link router files on app.js
import userRouter from './routes/user.router.js'

//for category router
import emergencyRouter from './routes/emergency.router.js'

//to load to cors function resolve cors problem
app.use(cors());

//to load the configuration of body parser
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({"extended":true}));

//application level middleware check re base url
app.use("/user",userRouter);
app.use("/emergency",emergencyRouter);
// app.get("/",(req,res)=>{

// })

// Function to get the machine's IP address
function getLocalIP() {
  const nets = networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
      if (net.family === 'IPv4' && !net.internal) {
        return net.address;
      }
    }
  }
  return 'localhost'; // Fallback to localhost if no IP found
}

const PORT = 3001;
const IP = getLocalIP();

app.listen(PORT, IP, () => {
  console.log(`Server running at http://${IP}:${PORT}`);
  // Save the IP to a file for the frontend to read
  writeFileSync('./server_ip.txt', IP);
});

//server pr application ke main configuration ka code likha jayega

//server base url check krke router pr jayega
//backenf wale sare url maintain kre