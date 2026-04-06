import React from 'react';
import { Typography, Button, Tag, Space } from 'antd';
import { EditOutlined } from '@ant-design/icons';
import CustomTable from '../../../components/CustomTable';

const { Text } = Typography;

const SystemConfigTable = ({ configs, loading, onEdit }) => {
    const columns = [
        {
            title: 'Tên cấu hình (Key)',
            dataIndex: 'key',
            key: 'key',
            width: '30%',
            render: (key) => <Text strong style={{ color: '#1E293B', fontSize: '15px' }}>{key}</Text>
        },
        {
            title: 'Giá trị',
            dataIndex: 'value',
            key: 'value',
            width: '15%',
            align: 'center',
            render: (value, record) => {
                const type = record.type.toLowerCase();
                if (type === 'boolean') {
                    const isTrue = value.toLowerCase() === 'true';
                    return (
                        <span style={{ 
                            backgroundColor: isTrue ? '#d1fae5' : '#fee2e2', 
                            color: isTrue ? '#10b981' : '#ef4444', 
                            padding: '4px 12px', 
                            borderRadius: '8px', 
                            fontWeight: 600, 
                            fontSize: '12px' 
                        }}>
                            {isTrue ? 'Đang bật' : 'Đang tắt'}
                        </span>
                    );
                }
                if (type === 'number') {
                    return (
                        <span style={{ 
                            backgroundColor: '#e0e7ff', 
                            color: '#4f46e5', 
                            padding: '4px 12px', 
                            borderRadius: '8px', 
                            fontWeight: 600, 
                            fontSize: '13px' 
                        }}>
                            {value}
                        </span>
                    );
                }
                return <Tag style={{ fontWeight: 500, borderRadius: '6px' }}>{value}</Tag>;
            }
        },
        {
            title: 'Mô tả chi tiết',
            dataIndex: 'description',
            key: 'description',
            render: (text) => <Text type="secondary" style={{ color: '#64748b' }}>{text || '—'}</Text>
        },
        {
            title: 'Hành động',
            key: 'action',
            align: 'center',
            width: '10%',
            render: (_, record) => (
                <Space>
                    <Button 
                        type="text" 
                        icon={<EditOutlined style={{ color: '#4318FF', fontSize: '18px' }} />} 
                        onClick={() => onEdit(record)}
                        style={{ background: 'rgba(67, 24, 255, 0.05)', borderRadius: '8px' }} 
                    />
                </Space>
            ),
        },
    ];

    return (
        <CustomTable 
            columns={columns} 
            dataSource={configs} 
            rowKey="id" 
            loading={loading}
            pagination={false} 
        />
    );
};

export default SystemConfigTable;