var fs = require('fs'), path = require('path');

function getProjectId() {
    var config = fs.readFileSync('config.xml').toString();
    var parseString = require('xml2js').parseString;
    var id;
    parseString(config, function (err, result) {
        id = result.widget.$['id'];
    });
    return id || null;
}


module.exports = function(context) {
      var projectId = getProjectId();   
      var javaFile = path.join(context.opts.projectRoot, "platforms", "android", "app", "src", "main", "java", "com", "cordova", "plugin", "splashscreenvideo", "VideoDialogFragment.java");
    console.log("✅ javaFile: " + javaFile);    
    if (fs.existsSync(javaFile)) {
     
      fs.readFile(javaFile, 'utf8', function (err,data) {
        
        if (err) {
          throw new Error('🚨 Unable to read VideoDialogFragment.java: ' + err);
        }
        
        var result = data;
        result = data.replace(/APP_ID_PLACEHOLDER/g, projectId);
        
        fs.writeFile(javaFile, result, 'utf8', function (err) {
          if (err) 
            {throw new Error('🚨 Unable to write into VideoDialogFragment.java: ' + err);}
          else 
            {console.log("✅ VideoDialogFragment.java edited successfuly");}
        });
      });
    } else {
        throw new Error("🚨 WARNING: VideoDialogFragment.java was not found. The build phase may not finish successfuly");
    }
  }
