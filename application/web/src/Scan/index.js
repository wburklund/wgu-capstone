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

import React from 'react';
import { Button, Header, Image, Segment, Grid, Input } from 'semantic-ui-react';
import Xray from './x-ray.png'

async function predict(accessKey, file) {
  let fullFile = await file.arrayBuffer();
  const response = await fetch("http://capstone-api.wburklund.com/predict", {
    headers: {
      'X-API-KEY': accessKey
    },
    method: 'POST',
    body: fullFile
  }).then(response => response.text());
  return response;
}

class Scan extends React.Component {
  handleFileChange = async (event) => {
    let file = event.target.files[0]
    let url = URL.createObjectURL(file);
    this.setState({'image': file, 'imageUrl': url})
  }

  handlePredictButtonClick = async () => {
    let resp = await predict(this.props.accessKey, this.state.image)
    this.setState({'scanResult': resp})
  }

  render() {
    const getScanMessage = () => {
      switch(this.state?.scanResult) {
        case undefined:
        case null:
          return "Click the button below to scan this image."
        case 'Normal':
          return "The scan did not find signs of pneumonia."
        case 'Pneumonia':
          return "The scan found signs of pneumonia."
      }
    }

    return (
          <Segment placeholder style={{ height: '100%', width: '100%', paddingTop: '15px' }}>
            {this.state?.image == null &&
              <>
                <Header icon>
                  <Image src={Xray} />
                  <br></br>
                  Please upload a chest X-ray image.
                </Header>
                <Button as='label' color='blue' htmlFor='fileInput'>Select Image</Button>
              </>
            }
            {
              this.state?.image != null &&
              <Grid columns={2} style={{ height: '100%' }}>
                <Grid.Column>
                  <Image src={this.state.imageUrl} fluid />
                </Grid.Column>
                <Grid.Column>
                  <Header>{getScanMessage()}</Header>
                  <Button onClick={this.handlePredictButtonClick}>
                    Scan Image
                  </Button>
                </Grid.Column>
              </Grid>
            }
            <Input ref={this.fileInputRef} type='file' id='fileInput' style={{ display: 'none' }} onChange={this.handleFileChange} />
          </Segment>
    );
  }
}

export default Scan;
