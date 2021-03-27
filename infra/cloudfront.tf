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

resource "aws_cloudfront_distribution" "capstone_web" {
    aliases = [
        "capstone.wburklund.com"
    ]
    default_root_object = "index.html"
    enabled = true
    is_ipv6_enabled = true
    price_class = "PriceClass_100"

    default_cache_behavior {
        allowed_methods = [
            "GET",
            "HEAD",
        ]
        cached_methods = [
            "GET",
            "HEAD",
        ]
        target_origin_id = "capstone.wburklund.com"
        viewer_protocol_policy = "redirect-to-https"

        forwarded_values {
            cookies {
                forward = "none"
            }
            query_string = false
        }
    }

    origin {
        domain_name = "${aws_s3_bucket.capstone_web_assets.bucket}.s3.amazonaws.com"
        origin_id = "capstone.wburklund.com"

        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.capstone_web.cloudfront_access_identity_path
        }
    }

    restrictions {
        geo_restriction {
          restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn = data.aws_acm_certificate.wildcard_useast1.arn
        cloudfront_default_certificate = false
        minimum_protocol_version = "TLSv1.2_2019"
        ssl_support_method = "sni-only"
    }
}

resource "aws_cloudfront_origin_access_identity" "capstone_web" {
    comment = "access-identity-"
}
