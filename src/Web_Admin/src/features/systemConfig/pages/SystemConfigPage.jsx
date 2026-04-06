import React, { useState, useEffect } from 'react';
import { message, Tabs } from 'antd';
import { SettingOutlined, CalendarOutlined, DollarOutlined, UserSwitchOutlined } from '@ant-design/icons';
import { systemConfigApi } from '../api/systemConfigApi';

import SystemConfigTable from '../components/SystemConfigTable';
import SystemConfigModal from '../components/SystemConfigModal';

import PageHeader from '../../../components/PageHeader';
import SectionCard from '../../../components/SectionCard';

const SystemConfigPage = () => {
    const [groupedConfigs, setGroupedConfigs] = useState({});
    const [loading, setLoading] = useState(false);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingItem, setEditingItem] = useState(null);

    const fetchConfigs = async () => {
        setLoading(true);
        try {
            const response = await systemConfigApi.getAllConfigsGrouped();
            if (response.success) {
                setGroupedConfigs(response.data);
            }
        } catch (error) {
            message.error('Không thể tải danh sách cấu hình hệ thống!');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchConfigs();
    }, []);

    const handleOpenEditModal = (record) => {
        setEditingItem(record);
        setIsModalOpen(true);
    };

    const handleCloseModal = () => {
        setIsModalOpen(false);
        setEditingItem(null);
    };

    const tabConfig = {
        General: { label: 'Cài đặt chung', icon: <SettingOutlined /> },
        Booking: { label: 'Vận hành & Đặt lịch', icon: <CalendarOutlined /> },
        Finance: { label: 'Tài chính & Phí', icon: <DollarOutlined /> },
        Behavior: { label: 'Hành vi khách hàng', icon: <UserSwitchOutlined /> },
    };

    const EXPECTED_GROUPS = ['General', 'Booking', 'Finance', 'Behavior'];

    const tabItems = EXPECTED_GROUPS.map((groupKey) => ({
        key: groupKey,
        label: (
            <span style={{ fontWeight: 500 }}>
                {tabConfig[groupKey].icon}
                {tabConfig[groupKey].label}
            </span>
        ),
        children: (
            <SystemConfigTable 
                configs={groupedConfigs[groupKey] || []} 
                loading={loading} 
                onEdit={handleOpenEditModal} 
            />
        )
    }));

    return (
        <div style={{ width: '100%', flex: 1, minWidth: 0 }}>
            <PageHeader title="Cấu hình Hệ thống (System Settings)" />

            <SectionCard style={{ minHeight: 'calc(100vh - 160px)' }}>
                <Tabs 
                    defaultActiveKey="General" 
                    items={tabItems} 
                    size="large"
                    tabBarStyle={{ marginBottom: '24px', borderBottom: '1px solid #f1f5f9' }}
                />
            </SectionCard>

            <SystemConfigModal 
                isOpen={isModalOpen}
                onClose={handleCloseModal}
                onSuccess={fetchConfigs}
                editingConfig={editingItem}
            />
        </div>
    );
};

export default SystemConfigPage;