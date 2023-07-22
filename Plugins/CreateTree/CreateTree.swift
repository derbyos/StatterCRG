//
//  File.swift
//  
//
//  Created by gandreas on 7/22/23.
//

import Foundation
import PackagePlugin

@main
struct CreateTree: BuildToolPlugin {
    
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let inputDefinition = target.directory.appending("TreeDefinition")
        let output = context.pluginWorkDirectory.appending("TreeDefinition.swift")
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
