var hl7 = require('simple-hl7');

///////////////////SERVER/////////////////////
var app = hl7.tcp();

app.use(function(req, res, next) {
  //req.msg is the HL7 message
  console.log('******message received*****')
  console.log(req.msg.log());
  next();
})

app.use(function(req, res, next){
  //res.ack is the ACK
  //acks are created automatically

  //send the res.ack back
  console.log('******sending ack*****')
  res.ack.addSegment('MSA', 'AA','D');
  //res.ack()
  //console.log(res.ack)
  res.end()
})

app.use(function(err, req, res, next) {
  //error handler
  //standard error middleware would be
  console.log('******ERROR*****')
  console.log(err);
  var msa = res.ack.getSegment('MSA');
  msa.setField(1, 'AR');
  res.ack.addSegment('ERR', err.message);
  res.end();
});

//Listen on port 7777
app.start(6020); //optionally pass encoding here, app.start(1234, 'latin-1');