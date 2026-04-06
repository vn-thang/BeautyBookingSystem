import React from 'react';
import { Row, Col, Card, Typography, Image } from 'antd';

const { Text } = Typography;

const StoreDocuments = ({ store }) => {
  return (
    <Row gutter={[24, 24]}>
      <Col xs={24} lg={12}>
        <Card 
          size="small" 
          title={<Text style={{ color: '#475569', fontWeight: 600 }}>1. Ảnh đại diện (Avatar)</Text>} 
          style={{ width: '100%', height: '100%', backgroundColor: '#f8fafc', borderColor: '#e2e8f0', borderRadius: '12px' }} 
        >
          <div style={{ textAlign: 'center', padding: '16px 0' }}>
            {store.avatarUrl ? (
              <Image width={150} height={150} src={store.avatarUrl} style={{ borderRadius: '12px', objectFit: 'cover', border: '3px solid #fff', boxShadow: '0 4px 12px rgba(0,0,0,0.08)' }} />
            ) : (
              <Text type="secondary">Chưa có ảnh đại diện</Text>
            )}
          </div>
        </Card>
      </Col>

      <Col xs={24} lg={12}>
        <Card 
          size="small" 
          title={<Text style={{ color: '#475569', fontWeight: 600 }}>2. Giấy phép kinh doanh</Text>} 
          style={{ width: '100%', height: '100%', backgroundColor: '#f8fafc', borderColor: '#e2e8f0', borderRadius: '12px' }} 
        >
          <div style={{ textAlign: 'center', padding: '16px 0' }}>
            {store.businessLicenseUrl ? (
              <Image width={280} src={store.businessLicenseUrl} style={{ borderRadius: '12px', border: '3px solid #fff', boxShadow: '0 4px 12px rgba(0,0,0,0.08)' }} />
            ) : (
              <Text type="secondary">Chưa tải lên giấy phép</Text>
            )}
          </div>
        </Card>
      </Col>
    </Row>
  );
};

export default StoreDocuments;