/*
    Copyright 2015 Australian National Botanic Gardens

    This file is part of NSL-domain-plugin.

    Licensed under the Apache License, Version 2.0 (the "License"); you may not
    use this file except in compliance with the License. You may obtain a copy
    of the License at http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
package au.org.biodiversity.nsl

import org.codehaus.groovy.grails.plugins.GrailsPlugin

class NslDomainService {
    def pluginManager
    def grailsApplication

    static final Integer currentVersion = 11

    File getDdlFile() {
        GrailsPlugin plugin = pluginManager.allPlugins.find { it.name.startsWith('nslDomain') }
        log.info "found $plugin.name with path ${plugin.pluginPath}"
        File pluginDir = grailsApplication.mainContext.getResource(plugin.pluginPath).file
        File file = new File(pluginDir, "sql/nsl-ddl.sql")
        log.info "nsl-ddl.sql file path $file.absolutePath"
        return file
    }

    def checkUpToDate() {
        try {
            DbVersion.get(1)?.version == currentVersion
        } catch (e) {
            log.error e.message
            return false
        }
    }
}
