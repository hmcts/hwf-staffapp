package simulations

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._
import com.typesafe.config._



class StaffAppPerformance extends Simulation
with HttpConfiguration
{
  val conf = ConfigFactory.load()
  val baseurl = conf.getString("baseUrl")
  val httpconf = httpProtocol.baseURL(baseurl).disableCaching

  val scenario1 = scenario("Happy path for Help with Fees staff app")

//////    .exec(http("Start Session")
//////        .get("/users/sign_in"))

    //////  Step One  //////

//////    .exec(http("Store authenticity token")
//////        .get("/users/sign_in")
//////        .check(css("input[name='authenticity_token']", "value").saveAs("csrfCookie")))

    .exec(http("Logging in")
        .put("/users/sign_in")
        .formParam("user[email]", "alexa.ballantine+2@digital.justice.gov.uk")
//////        .formParam("authenticity_token", session => {
//////              session("csrfCookie").as[String]
            })
        .check(status.is(200)))


    //////  Step Two  //////

//////    .exec(http("Step Two")
//////        .put("/questions/fee?locale=en")
//////        .formParam("fee[paid]", "false")
//////        .formParam("authenticity_token", session => {
//////              session("csrfCookie").as[String]
//////            })
//////        .check(status.is(200)))

 
  val userCount = conf.getInt("users")
  val durationInSeconds  = conf.getLong("duration")

  setUp(
    scenario1.inject(rampUsers(userCount) over (durationInSeconds seconds)).protocols(httpconf)
  )

}
