def slurper = new ConfigSlurper()
// fix classloader problem using ConfigSlurper in job dsl
slurper.classLoader = this.class.classLoader
def config = slurper.parse(readFileFromWorkspace('microservices.dsl'))

// create job for every microservice
config.microservices.each { name, data ->
  createBuildJob(name,data)
  createITestJob(name,data)
  createDeployJob(name,data)
}

// create nested build pipeline view
nestedView('Build-Pipeline') { 
   description('Shows the service build pipelines')
   columns {
      status()
      weather()
   }
   views {
      config.microservices.each { name,data ->
         println "creating build pipeline subview for ${name}"
         buildPipelineView("${name}") {
            configure { view ->
        view / buildCard(class: 'au.com.centrumsystems.hudson.plugin.buildpipeline.extension.StandardBuildCard')
        view / columnHeaders(class: 'au.com.centrumsystems.hudson.plugin.buildpipeline.extension.NullColumnHeader')
        view / rowHeaders(class: 'au.com.centrumsystems.hudson.plugin.buildpipeline.extension.SimpleRowHeader')
}
            selectedJob("${name}-build")
            triggerOnlyLatestJob(true)
    	    alwaysAllowManualTrigger(true)
        	showPipelineParameters(true)
            showPipelineParametersInHeaders(true)
   	    	showPipelineDefinitionHeader(true)
    	    startsWithParameters(true)
         }
      }
   }
}

def createBuildJob(name,data) {

  freeStyleJob("${name}-build") {
  
    scm {
      git {
        remote {
          url(data.url)
        }
        branch(data.branch)
      }
    }
  
    triggers {
       scm('0 0 1 */2 *')
    }

    steps {
      maven {
        mavenInstallation('3.1.1')
        goals('clean install')
      }
    }

    publishers {
      archiveJunit('/target/surefire-reports/*.xml')
      downstream("${name}-itest", 'SUCCESS')
    }
  }

}

def createITestJob(name,data) {
  freeStyleJob("${name}-itest") {
    publishers {
      downstream("${name}-deploy", 'SUCCESS')
    }
  }
}

def createDeployJob(name,data) {
  freeStyleJob("${name}-deploy") {}
}
