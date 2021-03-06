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
dataSource {
    pooled = true
    jmxExport = true

}
hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = false
//    cache.region.factory_class = 'net.sf.ehcache.hibernate.EhCacheRegionFactory' // Hibernate 3
    cache.region.factory_class = 'org.hibernate.cache.ehcache.EhCacheRegionFactory' // Hibernate 4
//    singleSession = true // configure OSIV singleSession mode
}

// environment specific settings
//You may want to change these settings... or create a nslimport db just for this

environments {
    development {
        dataSource_nsl {
            pooled = true
            driverClassName = "org.postgresql.Driver"
            username = "nsldev"
            password = "nsldev"
            dialect = "org.hibernate.dialect.PostgreSQLDialect"
            dbCreate = "update"
            url = "jdbc:postgresql://localhost:5432/nslimport"
            formatSql = false
            logSql = false
            properties {
                defaultTransactionIsolation = java.sql.Connection.TRANSACTION_READ_UNCOMMITTED
                initialSize = 2
                maxActive = 5
                minEvictableIdleTimeMillis = 1800000
                timeBetweenEvictionRunsMillis = 1800000
                numTestsPerEvictionRun = 3
                testOnBorrow = true
                testWhileIdle = true
                testOnReturn = true
                validationQuery = "SELECT 1"
            }
        }

    }
    test {
        dataSource_nsl {
            pooled = true
            driverClassName = "org.postgresql.Driver"
            username = "nsldev"
            password = "nsldev"
            dialect = "org.hibernate.dialect.PostgreSQLDialect"
            dbCreate = "update"
            url = "jdbc:postgresql://localhost:5432/nslimport"
            formatSql = false
            logSql = false
            properties {
                defaultTransactionIsolation = java.sql.Connection.TRANSACTION_READ_UNCOMMITTED
                initialSize = 2
                maxActive = 5
                minEvictableIdleTimeMillis = 1800000
                timeBetweenEvictionRunsMillis = 1800000
                numTestsPerEvictionRun = 3
                testOnBorrow = true
                testWhileIdle = true
                testOnReturn = true
                validationQuery = "SELECT 1"
            }
        }

    }
    production {
        dataSource {
            pooled = true
            driverClassName = "org.postgresql.Driver"
            username = "nsldev"
            password = "nsldev"
            dialect = "org.hibernate.dialect.PostgreSQLDialect"
            dbCreate = "update"
            url = "jdbc:postgresql://localhost:5432/nslimport"
            formatSql = false
            logSql = false
            properties {
               // See http://grails.org/doc/latest/guide/conf.html#dataSource for documentation
               jmxEnabled = true
               initialSize = 5
               maxActive = 50
               minIdle = 5
               maxIdle = 25
               maxWait = 10000
               maxAge = 10 * 60000
               timeBetweenEvictionRunsMillis = 5000
               minEvictableIdleTimeMillis = 60000
               validationQuery = "SELECT 1"
               validationQueryTimeout = 3
               validationInterval = 15000
               testOnBorrow = true
               testWhileIdle = true
               testOnReturn = false
               jdbcInterceptors = "ConnectionState"
               defaultTransactionIsolation = java.sql.Connection.TRANSACTION_READ_COMMITTED
            }
        }
    }
}
