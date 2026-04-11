import React from 'react';
import { Typography, Tag } from 'antd';
import { CrownOutlined, TrophyOutlined } from '@ant-design/icons';
import SectionCard from '../../../components/SectionCard';
import CustomTable from '../../../components/CustomTable';

const { Text } = Typography;

const TopStores = ({ data }) => {
    const columns = [
        {
            title: 'Top',
            key: 'index',
            width: 70,
            align: 'center',
            render: (text, record, index) => {
                let color = '#cbd5e1'; 
                if (index === 0) color = '#facc15'; 
                if (index === 1) color = '#94a3b8'; 
                if (index === 2) color = '#f87171'; 
                
                return index < 3 ? (
                    <CrownOutlined style={{ color, fontSize: '22px' }} />
                ) : (
                    <Text strong type="secondary">{index + 1}</Text>
                );
            }
        },
        {
            title: 'Tên Cửa hàng',
            dataIndex: 'storeName',
            key: 'storeName',
            render: (name) => <Text strong style={{ color: '#1E293B', fontSize: '15px' }}>{name}</Text>
        },
        {
            title: 'Số lịch hẹn',
            dataIndex: 'totalBookings',
            key: 'totalBookings',
            align: 'center',
            render: (val) => (
                <span style={{ background: '#e0e7ff', color: '#4f46e5', padding: '4px 10px', borderRadius: '6px', fontWeight: 600 }}>
                    {val} đơn
                </span>
            )
        },
        {
            title: 'Doanh thu',
            dataIndex: 'totalRevenue',
            key: 'totalRevenue',
            align: 'right',
            render: (val) => <Text style={{ color: '#10b981', fontWeight: 700, fontSize: '15px' }}>{val?.toLocaleString()} ₫</Text>
        }
    ];

    return (
        <SectionCard 
            title="Top 5 Cửa Hàng Doanh Thu Cao Nhất" 
            icon={<TrophyOutlined style={{ color: '#facc15' }} />}
            style={{ marginBottom: 0, height: '100%' }}
        >
            <CustomTable 
                columns={columns} 
                dataSource={data} 
                rowKey="storeId" 
                pagination={false} 
            />
        </SectionCard>
    );
};

export default TopStores;