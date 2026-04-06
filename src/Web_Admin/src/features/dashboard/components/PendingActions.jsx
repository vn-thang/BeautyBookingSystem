import React from 'react';
import { Row, Col, Statistic, Typography } from 'antd';
import { ShopOutlined, DollarOutlined, WarningOutlined, RightOutlined, ExclamationCircleOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom'; 
import SectionCard from '../../../components/SectionCard';

const { Text } = Typography;

const PendingActions = ({ data }) => {
    const navigate = useNavigate();

    const actions = [
        {
            title: 'Cửa hàng chờ duyệt',
            count: data?.pendingStores || 0,
            icon: <ShopOutlined />,
            color: '#1677ff', bg: '#e6f4ff', 
            path: '/stores'
        },
        {
            title: 'Yêu cầu rút tiền',
            count: data?.pendingPayouts || 0,
            icon: <DollarOutlined />,
            color: '#52c41a', bg: '#f6ffed',
            path: '/finance/withdrawals'
        },
        {
            title: 'Đánh giá bị báo cáo',
            count: data?.reportedReviews || 0,
            icon: <WarningOutlined />,
            color: '#ff4d4f', bg: '#fff2f0',
            path: '/reviews'
        }
    ];

    return (
        <SectionCard 
            title="Việc cần xử lý ngay" 
            icon={<ExclamationCircleOutlined style={{ color: '#f59e0b' }} />}
            style={{ marginBottom: 0 }}
        >
            <Row gutter={[16, 16]}>
                {actions.map((item, index) => (
                    <Col xs={24} sm={8} key={index}>
                        <div 
                            style={{
                                background: item.bg,
                                borderRadius: '12px',
                                padding: '16px 20px',
                                border: `1px solid ${item.bg}`,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'space-between',
                                cursor: 'pointer',
                                transition: 'all 0.3s ease',
                                height: '100%'
                            }}
                            onMouseEnter={e => {
                                e.currentTarget.style.boxShadow = '0 4px 12px rgba(0,0,0,0.05)';
                                e.currentTarget.style.transform = 'translateY(-2px)';
                                e.currentTarget.style.borderColor = item.color;
                            }}
                            onMouseLeave={e => {
                                e.currentTarget.style.boxShadow = 'none';
                                e.currentTarget.style.transform = 'translateY(0px)';
                                e.currentTarget.style.borderColor = item.bg;
                            }}
                            onClick={() => navigate(item.path)}
                        >
                            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                                <div style={{ 
                                    width: 44, height: 44, borderRadius: '50%', 
                                    background: '#fff', display: 'flex', 
                                    justifyContent: 'center', alignItems: 'center',
                                    color: item.color, fontSize: '20px',
                                    boxShadow: '0 2px 6px rgba(0,0,0,0.04)'
                                }}>
                                    {item.icon}
                                </div>
                                <div style={{ display: 'flex', flexDirection: 'column' }}>
                                    <Text strong style={{ fontSize: '15px', color: item.color, marginBottom: 2 }}>
                                        {item.title}
                                    </Text>
                                    <Text type="secondary" style={{ fontSize: '12px' }}>Vui lòng kiểm tra</Text>
                                </div>
                            </div>

                            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <Statistic 
                                    value={item.count} 
                                    styles={{ 
                                        color: item.count > 0 ? item.color : '#94a3b8', 
                                        fontWeight: 800, 
                                        fontSize: '28px',
                                        lineHeight: 1
                                    }} 
                                />
                                <RightOutlined style={{ color: '#cbd5e1', fontSize: '14px', marginTop: 4 }} />
                            </div>
                        </div>
                    </Col>
                ))}
            </Row>
        </SectionCard>
    );
};

export default PendingActions;