import React from 'react';
import { Card, Typography } from 'antd';

const { Text } = Typography;

const SectionCard = ({ title, icon, children, style, titleColor = '#2B3674' }) => {
  return (
    <Card 
      variant="borderless" 
      style={{ 
        borderRadius: '20px', 
        boxShadow: '0px 4px 24px rgba(112, 144, 176, 0.08)', 
        marginBottom: '24px',
        ...style 
      }}
      styles={{ header: { borderBottom: '1px solid #f1f5f9' } }}
      title={
        title ? (
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            {icon && <span style={{ fontSize: '20px' }}>{icon}</span>}
            <Text style={{ fontSize: '16px', fontWeight: 700, color: titleColor }}>{title}</Text>
          </div>
        ) : null
      }
    >
      {children}
    </Card>
  );
};

export default SectionCard;