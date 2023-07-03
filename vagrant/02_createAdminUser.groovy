import java.util.logging.Logger
import jenkins.model.*
import hudson.security.*

def logger = Logger.getLogger("")
def env = System.getenv()
def instance = Jenkins.getInstance()

logger.info("Creating admin user")

String password = env.JENKINS_ADMIN_PASSWORD ?: "admin"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", password)
instance.setSecurityRealm(hudsonRealm)

def strategy = (GlobalMatrixAuthorizationStrategy) instance.getAuthorizationStrategy()
strategy.add(Jenkins.ADMINISTER, "admin")
instance.setAuthorizationStrategy(strategy)

if (env.JENKINS_ADMIN_EMAIL) {
    def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
    jenkinsLocationConfiguration.setAdminAddress(env.JENKINS_ADMIN_EMAIL)
    jenkinsLocationConfiguration.save()
}

instance.save()