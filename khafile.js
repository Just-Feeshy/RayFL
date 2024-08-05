let project = new Project('My Project');

const BUILD_DIR = 'build';
const INDEX_HTML = 'index.html';

project.addAssets('assets/**.png');
project.addAssets('shaders/**');
project.addSources('source');
project.addParameter('-dce full'); // Dead Code Elimination (Haxe, do your thing!)
project.buildPath = BUILD_DIR;

if(platform === Platform.HTML5) {
    project.addDefine('js-es6');
}

resolve(project);

function copy_callback(err) {
    if (err) throw err;
}

if (platform == Platform.HTML5) {
    const fs = require('fs');
    const BUILD_INDEX = BUILD_DIR + '/html5/' + INDEX_HTML;
    fs.copyFile(INDEX_HTML, BUILD_INDEX, copy_callback);
}
