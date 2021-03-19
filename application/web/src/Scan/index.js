import React from 'react';
import { Button, Header, Icon, Segment, Grid, Input } from 'semantic-ui-react';

async function predict(accessKey, file) {
  let fullFile = await file.arrayBuffer();
  const response = await fetch("http://capstone-api.wburklund.com/predict", {
      headers: {
          'X-API-KEY': accessKey
      },
      method: 'POST',
      body: fullFile
  });
  return response;
}

class Scan extends React.Component {
  handleFileChange = (event) => {
    predict(this.props.accessKey, event.target.files[0]);
  }

  render() {
    return (
      <Grid style={{ width: '100%', height: '100%' }}>
        <Grid.Column>
          <Segment placeholder>
            <Header icon>
              <Icon name='pdf file outline' />
              Please upload a chest X-ray image.
            </Header>
            <Button as='label' color='blue' htmlFor='fileInput'>Select Image</Button>
            <Input ref={this.fileInputRef} type='file' id='fileInput' style={{ display: 'none' }} onChange={this.handleFileChange} />
          </Segment>
        </Grid.Column>
      </Grid>
    );
  }
}

export default Scan;
