/*
  WGU Capstone Project
  Copyright (C) 2021 Will Burklund

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

data "aws_route53_zone" "domain" {
  provider = aws.us_east_1

  name = "wburklund.com"
}

resource "aws_route53_record" "capstone_api" {
  provider = aws.us_east_1

  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "capstone-api.${data.aws_route53_zone.domain.name}"
  records = [aws_lb.capstone_api.dns_name]
  ttl     = 60
  type    = "CNAME"
}

resource "aws_route53_record" "capstone_pipeline" {
  provider = aws.us_east_1

  name    = aws_apigatewayv2_domain_name.capstone_pipeline.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.capstone_pipeline.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.capstone_pipeline.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "capstone_web" {
  provider = aws.us_east_1

  name    = "capstone.${data.aws_route53_zone.domain.name}"
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.capstone_web.domain_name
    zone_id                = aws_cloudfront_distribution.capstone_web.hosted_zone_id
  }
}
