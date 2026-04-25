<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::table('study_groups', function (Blueprint $table) {
            if (!Schema::hasColumn('study_groups', 'expected_opening_time')) {
                $table->dateTime('expected_opening_time')->nullable()->after('status');
            }
            if (!Schema::hasColumn('study_groups', 'payment_deadline')) {
                $table->dateTime('payment_deadline')->nullable()->after('expected_opening_time');
            }
            // Update current_members default to 0
            $table->integer('current_members')->default(0)->change();
        });
    }

    public function down()
    {
        Schema::table('study_groups', function (Blueprint $table) {
            $table->dropColumn(['expected_opening_time', 'payment_deadline']);
        });
    }
};
