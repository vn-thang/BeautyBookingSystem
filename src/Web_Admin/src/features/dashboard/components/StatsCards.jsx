import React from 'react';
import { Row, Col, Card, Statistic, Typography, Skeleton } from 'antd';
import { 
    DollarCircleFilled, CalendarFilled, 
    UsergroupAddOutlined, WalletFilled, 
    RightOutlined 
} from '@ant-design/icons';
import { useNavigate } from 'react-router-dom'; 

const { Text } = Typography;

const StatsCards = ({ data, loading }) => {
    const navigate = useNavigate();
    const statConfigs = [
        { 
            title: 'Tổng Giao Dịch (GMV)', 
            value: data?.totalRevenue || 0, 
            prefix: <DollarCircleFilled />, 
            color: '#8c8c8c', bg: '#f5f5f5', suffix: '₫', 
        },
        { 
            title: 'Hoa Hồng Thu Được', 
            value: data?.totalCommission || 0, 
            prefix: <WalletFilled />, 
            color: '#1677ff', bg: '#e6f4ff', suffix: '₫', 
            path: '/transactions'
        },
        { 
            title: 'Tổng Lịch Hẹn', 
            value: data?.totalBookings || 0, 
            prefix: <CalendarFilled />, 
            color: '#52c41a', bg: '#f6ffed',
            path: '/bookings' 
        },
        { 
            title: 'Người dùng Mới', 
            value: data?.totalStores || 0, 
            prefix: <UsergroupAddOutlined />, 
            color: '#faad14', bg: '#fffbe6',
            path: '/users'
        }
    ];

    return (
        <Row gutter={[24, 24]} style={{ marginBottom: 24 }}>
            {statConfigs.map((stat, index) => (
                <Col xs={24} sm={12} xl={6} key={index}>
                    <Card 
                        hoverable 
                        onClick={() => navigate(stat.path)}
                        style={{ 
                            borderRadius: '16px',
                            border: '1px solid #f0f0f0', 
                            boxShadow: '0 2px 8px rgba(0,0,0,0.02)', 
                            transition: 'all 0.3s ease' 
                        }}
                        styles={{ body: { padding: '24px' } }}
                    >
                        <Skeleton loading={loading} active avatar paragraph={{ rows: 1 }}>
                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                                
                                <div style={{ display: 'flex', alignItems: 'center' }}>
                                    <div style={{ 
                                        width: 56, height: 56, borderRadius: '14px', 
                                        background: stat.bg, color: stat.color, 
                                        display: 'flex', justifyContent: 'center', alignItems: 'center', 
                                        fontSize: '28px', marginRight: 16 
                                    }}>
                                        {stat.prefix}
                                    </div>
                                    <div>
                                        <Text type="secondary" style={{ fontSize: '14px', fontWeight: 500, display: 'block', marginBottom: 4 }}>
                                            {stat.title}
                                        </Text>
                                        <Statistic 
                                            value={stat.value} 
                                            suffix={stat.suffix}
                                            style={{ color: '#1f1f1f', fontWeight: 700, fontSize: '24px', lineHeight: 1 }} 
                                        />
                                    </div>
                                </div>

                                <div style={{ opacity: 0.3, transition: 'opacity 0.3s' }} className="card-action-icon">
                                    <RightOutlined style={{ fontSize: '18px', color: stat.color }} />
                                </div>
                            </div>
                        </Skeleton>
                    </Card>
                </Col>
            ))}
        </Row>
    );
};

export default StatsCards;