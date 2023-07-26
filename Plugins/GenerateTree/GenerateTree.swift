//
//  CreateTree.swift
//  
//
//  Created by gandreas on 7/22/23.
//

import Foundation
import PackagePlugin

// if this is done as a build tool, then
// if multiple targets in a project use this SPM
// it will fail because duplicate things are trying
// to generate GenTree.swift
#if false
@main
struct CreateTree: BuildToolPlugin {
    
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let inputDefinition = target.directory.appending("TreeDefinition")
        let output = context.pluginWorkDirectory.appending("GenTree.swift")
        return [
            .buildCommand(displayName: "Generate Game Tree Structure",
                          executable: try context.tool(named: "treemaker").path,
                          arguments: [inputDefinition, output],
                          environment: [:],
                          inputFiles: [inputDefinition],
                          outputFiles: [output])
        ]
    }
}
#else

@main
struct GenerateTree: CommandPlugin {
    
    func performCommand(
        context: PluginContext,
        arguments: [String]
    ) throws {
        let executable = try context.tool(named: "treemaker")
        // include the config file as the first arg
        let destDir = context.package.directory.appending("Sources/StatterCRG/GenTree").string + "/"
        print("Generating tree in \(destDir)")
        let arguments: [String] = [
            context.package.directory.appending("Sources/StatterCRG/TreeDefinition").string,
            destDir,
        ]
        print("Executing \(executable) \(arguments)")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable.path.string)
        process.arguments = arguments

        try process.run()

        process.waitUntilExit()
        print("Done")


    }
}

#endif
