var solc = Npm.require('solc');

function has(object, key) {
  return object ? hasOwnProperty.call(object, key) : false;
}

'use strict';

class SolidityCompiler extends CachingCompiler {
	constructor() {
		super({
			compilerName: 'solidity',
			defaultCacheSize: 1024 * 1024 * 10,
		});
	}

	getCacheKey(inputFile) {
		return inputFile.getSourceHash();
	}

	compileResultSize(compileResult) {
		return compileResult.source.length + compileResult.sourceMap.length;
	}

	compileOneFile(inputFile) {
		var name = inputFile._resourceSlot.inputResource.path.split("/").pop();
		name = name.split('.')[0];

		var output = solc.compile(inputFile.getContentsAsString(), 1);

		if (has(output, 'errors')){
			console.log('errors for output file', output);
            return inputFile.error({
                message: "Solidity errors: " + String(output.errors)
            });
		}

		
		var results = output,
			jsContent = "";


		var addWeb3 = function(){
            jsContent += "var web3 = {};";

            jsContent += "if(typeof window.web3 !== 'undefined')";
            jsContent += "web3 = window.web3;";

            jsContent += "if(typeof window.web3 === 'undefined'";
            jsContent += "  && typeof Web3 !== 'undefined')";
            jsContent += "    web3 = new Web3();";
		};

		var addContractCode = function(contractName, name){
            var preparse = JSON.stringify(results.contracts[contractName].interface, null, '\t');
            jsContent += "\n\n " + name + ' = ' + ' web3.eth.contract(' + JSON.parse(preparse).trim() + ')' + '; \n\n';

            jsContent += "" + name + ".bytecode = '" + results.contracts[contractName].bytecode + "'; \n\n";
		};


		for (var contractName in results.contracts) {
            var correctedName = contractName.startsWith(":") ? contractName.substring(1) : contractName;
			if (correctedName == name) {
				addWeb3();
                addContractCode(contractName, name);
                console.log(' ');
				console.log('ADDED '+name+' to context');
			} else {
                addWeb3();
                addContractCode(contractName, correctedName);
                console.log(' ');
                console.log('ALSO ADDED '+correctedName+' to context', );
			}
		}

		return {
			source: jsContent,
			sourceMap: ''
		};
	}
	
	addCompileResult(inputFile, compileResult) {
		inputFile.addJavaScript({
			path: inputFile.getPathInPackage() + '.js',
			sourcePath: inputFile.getPathInPackage(),
			data: compileResult.source,
			sourceMap: compileResult.sourceMap,
		});
	}
}

Plugin.registerCompiler({
	extensions: ['sol'],
}, () => new SolidityCompiler());
