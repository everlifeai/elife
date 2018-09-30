'use strict'
const shortid = require('shortid')

/*      understand/
 * Cote.js has a automated discovery service that allows it to find
 * matching microservices anywhere on the network that share the same
 * 'environment' parameter.
 *
 *      problem/
 * We do not want nodes that are near each other (on the same machine or
 * on the same network) to start responding to each other's microservice
 * requests.
 *
 *      way/
 * We returns reasonably-unique identifier that we can use to partition
 * cote.js microservice environments and prevent nodes from interfering
 * with each other.
 */
console.log(shortid.generate())
