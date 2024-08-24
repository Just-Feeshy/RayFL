let project = new Project('My Project');
const BUILD_DIR = 'build';

project.addShaders('shaders/**');
project.addAssets('assets/**.png');
project.addSources('source');
project.addParameter('-dce full'); // Dead Code Elimination (Haxe, do your thing!)
project.buildPath = BUILD_DIR;

if(process.argv.indexOf('--debug') > 0) {
    project.addDefine('debug');
}

if(platform === Platform.HTML5) {
    project.addDefine('kha_html5_disable_automatic_size_adjust');
    project.addDefine('js-es6');
}

resolve(project);
